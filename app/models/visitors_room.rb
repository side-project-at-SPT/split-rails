class VisitorsRoom < ApplicationRecord
  belongs_to :visitor
  belongs_to :room
end
