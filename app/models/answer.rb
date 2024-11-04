require 'analytic/score_analytic'

class Answer < ApplicationRecord
  include ScoreAnalytic
  belongs_to :question
  belongs_to :response


  #Problem: The SQL queries are complex and hard to read.
  #Solution: Use ActiveRecord syntax more effectively and organize the query parts for clarity.

  def self.answers_by_question_for_reviewee_in_round(assignment_id, reviewee_id, q_id, round)
    #get all answers to this question
    Answer.select(:answer, :comments)
          .joins(:response)
          .joins('JOIN response_maps ON responses.map_id = response_maps.id')
          .joins(:question)
          .where(response_maps: { reviewed_object_id: assignment_id, reviewee_id: reviewee_id },
                 answers: { question_id: q_id },
                 responses: { round: round })
  end
  
  #Problem: The SQL queries are complex and hard to read.
  #Solution: Use ActiveRecord syntax more effectively and organize the query parts for clarity.

  def self.answers_by_question(assignment_id, q_id)
    Answer.select('DISTINCT answers.comments, answers.answer')
          .joins(:question)
          .joins(:response)
          .joins('JOIN response_maps ON responses.map_id = response_maps.id')
          .where(answers: { question_id: q_id }, response_maps: { reviewed_object_id: assignment_id })
  end

  #Problem: The SQL queries are complex and hard to read.
  #Solution: Use ActiveRecord syntax more effectively and organize the query parts for clarity.

  def self.answers_by_question_for_reviewee(assignment_id, reviewee_id, q_id)
    Answer.select(:answer, :comments)
          .joins(:response)
          .joins('JOIN response_maps ON responses.map_id = response_maps.id')
          .joins(:question)
          .where(response_maps: { reviewed_object_id: assignment_id, reviewee_id: reviewee_id },
                 answers: { question_id: q_id })
  end  
end
