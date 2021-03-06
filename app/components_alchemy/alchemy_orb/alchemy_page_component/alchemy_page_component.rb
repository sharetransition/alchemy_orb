class AlchemyOrb::AlchemyPageComponent::AlchemyPageComponent < AlchemyOrb::BaseComponent
	delegate :render, to: :helpers

	# include Alchemy::PagesHelper
	include AlchemyOrb::AlchemyHelper

	def initialize(page:)
		@page = page
		# @page = page# Also in Current.alchemy_edit_page if in edit
		# @preview_mode = preview_mode # Also in Current.alchemy_preview_mode
		# @options = options
		# @counter = counter
		# @locals = locals No point for now

		# Initialize hook for subclasses
		post_initialize if defined? post_initialize
	end

	# def custom_cache
	# 	false
	# end
end
