class Course < ApplicationRecord
  enum locale: Locale.code_name_to_db_encoding
  has_many :ta_mappings, dependent: :destroy
  has_many :tas, through: :ta_mappings
  has_many :assignments, dependent: :destroy
  belongs_to :instructor, class_name: 'User', foreign_key: 'instructor_id'
  belongs_to :institution, foreign_key: 'institutions_id'
  has_many :participants, class_name: 'CourseParticipant', foreign_key: 'parent_id', dependent: :destroy
  has_many :course_teams, foreign_key: 'parent_id', dependent: :destroy
  has_one :course_node, foreign_key: 'node_object_id', dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_paper_trail
  validates :name, presence: true
  validates :directory_path, presence: true
  # Return any predefined teams associated with this course
  # Author: ajbudlon
  # Date: 7/21/2008
  def get_teams
    CourseTeam.where(parent_id: id)
  end

  # Returns this object's submission directory
  def path
    raise 'Path can not be created. The course must be associated with an instructor.' if instructor_id.nil?

    Rails.root + '/pg_data/' + FileHelper.clean_path(User.find(instructor_id).name) + '/' + FileHelper.clean_path(directory_path) + '/'
  end

  def get_participants
    CourseParticipant.where(parent_id: id)
  end

  def get_participant(user_id)
    CourseParticipant.where(parent_id: id, user_id: user_id)
  end
  
  #Problem: The add_participant method has nested conditionals that can be simplified.
  #Solution: Use guard clauses to reduce nesting and improve readability.
  def add_participant(user_name)
    user = User.find_by(name: user_name)
    raise "No user account exists with the name #{user_name}. Please <a href='#{url_for(controller: 'users', action: 'new')}'>create</a> the user first." if user.nil?
  
    participant = CourseParticipant.find_by(parent_id: id, user_id: user.id)
    raise "The user #{user.name} is already a participant." if participant
  
    CourseParticipant.create(parent_id: id, user_id: user.id, permission_granted: user.master_permission_granted)
  end
  

  def copy_participants(assignment_id)
    participants = AssignmentParticipant.where(parent_id: assignment_id)
    errors = []
    error_msg = ''
    participants.each do |participant|
      user = User.find(participant.user_id)

      begin
        add_participant(user.name)
      rescue StandardError
        errors << $ERROR_INFO
      end
    end
    unless errors.empty?
      errors.each do |error|
        error_msg = error_msg + '<BR/>' + error if error
      end
      raise error_msg
    end
  end

  #Problem: The user_on_team? method manually flattens the array, which can be simplified.
  #Solution: Use flat_map for concise code.
  def user_on_team?(user)
    get_teams.flat_map(&:users).include?(user)
  end

  require 'analytic/course_analytic'
  include CourseAnalytic
end
