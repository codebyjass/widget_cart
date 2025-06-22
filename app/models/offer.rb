class Offer < ApplicationRecord
  self.inheritance_column = :type

  validates :name, :target_code, presence: true
  validates :active, inclusion: { in: [true, false] }

  scope :active, -> { where(active: true) }

  def discount(_items)
    raise NotImplementedError, "#{self.class} must implement #discount"
  end
end
