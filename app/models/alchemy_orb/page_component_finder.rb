class AlchemyOrb::PageComponentFinder
	def initialize(page:)
		@page = page
		@namespace = "alchemy_page/#{@page.layout_partial_name}_component".classify
	end


	def new(**args)
		@namespace.constantize.new(page: @page, **args)
	end

	def config
		Object.const_defined?("#{@namespace}::Config") ?
			"#{@namespace}::Config".constantize.new(page: @page) :
			AlchemyOrb::AlchemyPageComponent::Config.new(page: @page)
	end
end
