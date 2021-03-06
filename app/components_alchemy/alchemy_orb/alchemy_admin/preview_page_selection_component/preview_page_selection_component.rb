class AlchemyOrb::AlchemyAdmin::PreviewPageSelectionComponent::PreviewPageSelectionComponent < AlchemyOrb::AlchemyAdminComponent
  def initialize(selections = nil)
    return if !selections

    @selections = selections
    @collection = selections.map{|k, v| [v[:label], k]}
  end

  def render?
    @selections.present?
  end
end
