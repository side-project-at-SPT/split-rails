class VisitorsRoom < ApplicationRecord
  belongs_to :visitor
  belongs_to :room

  def ready!
    update!(ready: true)
  end
end
