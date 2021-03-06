module AlchemyOrb::ElementFileMerger
	extend self

	def call
		@templates = nil
		@merged_templates = {}
		@elements = []

		load_files

		while @merged_templates.keys.length < @templates.keys.length
			merge_templates
		end

		inject_templates
		fix_asset_paths

		merge_elements

		AlchemyOrb.log('Element files merged')
	end


	private

	def load_files
		element_files = Rails.root.join('config', 'alchemy', 'elements', '_*elements.yml')
		@templates = YAML.load(File.read(Rails.root.join('config', 'alchemy', 'content_templates.yml'))) || {}

		general_els = nil

		Dir[element_files].each do |path|
			element = YAML.load(File.read(path))

			# Make sure general elements come last in lists
			# if File.basename(path) == '_general_elements.yml'
			# 	general_els = element
			# else
			# end
			@elements += element if element.present?
		end

		# @elements += general_els
	end

	def deep_merge_with_some_arrays(h1, h2)
		h1.deep_merge(h2){ |key, this_val, other_val|
			if key == 'validate'
				this_val + other_val
			else
				other_val
			end
		}
	end

	def fix_asset_paths
		@elements.each do |element|
			element['contents'].presence.try do |contents|
				contents.each do |content|
					content.dig('settings', 'tinymce', 'content_css').presence.try do |asset|
						content['settings']['tinymce']['content_css'] = AlchemyOrb::AssetPath.get(asset)
					end
				end
			end
		end
	end

	def merge_templates
		@templates.each do |name, val|
			if val['<t'].blank?
				@merged_templates[name] = @templates.delete(name)
			elsif (val['<t'] - @merged_templates.keys).empty?
				exts = @templates[name].delete('<t')
				merged_template = {}
				exts.each do |ext|
					merged_template = deep_merge_with_some_arrays(merged_template, @merged_templates[ext])
				end
				@merged_templates[name] = deep_merge_with_some_arrays(merged_template, @templates.delete(name))
			end
		end
	end

	def inject_templates
		# Inject templates in elements
		@elements.map do |element|
			if element['contents'].blank?
				element
				next
			end

			merged_contents = []

			element['contents'].each do |content|
				if content['<t'].present?
					merged_content = {}
					exts = content.delete('<t')
					exts.each do |ext|
						raise "#{ext} not found" if @merged_templates[ext].nil?
						merged_content = deep_merge_with_some_arrays(merged_content, @merged_templates[ext])
					end
					merged_contents.push(deep_merge_with_some_arrays(merged_content, content))
				else
					merged_contents.push(content)
				end
			end

			element['contents'] = merged_contents
			element
		end
	end

	def merge_elements
		File.open(Rails.root.join('config', 'alchemy', 'elements.yml'), 'w') {|f|
			# Convert to json and then back to yaml will remove any aliases
			# https://stackoverflow.com/questions/3981128/ruby-yaml-write-without-aliases
			f.write YAML.load(@elements.to_json).to_yaml
		}
	end
end
