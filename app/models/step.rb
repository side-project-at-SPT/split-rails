class Step
  include ActiveModel::Attributes

  attribute :original_grid, default: { x: 0, y: 0, color: 'white', quantity: 0 }
  # attribute :destination_grid, Array



  #
end
