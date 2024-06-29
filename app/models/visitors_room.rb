class VisitorsRoom < ApplicationRecord
  belongs_to :visitor
  belongs_to :room

  def ready!
    update!(ready: true)
  end

  def unready!
    update!(ready: false)
  end
end
