class ProgramPdf < Prawn::Document

	def initialize(opening_keynote, periods, talks, closing_keynote)
		@periods = periods
		@talks = talks
		super(:page_size => "A4", :margin => 15, :page_layout => :landscape)
		setup
		day_periods = @periods.group_by(&:day).each_pair.to_a.sort_by { |(day,_)| day}.map { |(_,periods)| periods.sort_by(&:start_time) }

		draw_wednesday opening_keynote, day_periods[0]
		start_new_page
		draw_thursday day_periods[1]
		start_new_page
		draw_friday closing_keynote, day_periods[2]
	end
	attr_accessor :row

	def rem
		9.5
	end

	def dark_background_color
		"2E3E4D"
	end

	def light_background_color
		"A5ECDE"
	end

	def columns
		168
	end

	def rows
		23
	end

	def setup
		font_families.update("FiraSans" => {
			:normal => "#{Rails.root}/app/assets/fonts/FiraSans-Regular.ttf"
		})

		font_families.update("FiraSansMedium" => {
			:normal => "#{Rails.root}/app/assets/fonts/FiraSans-Medium.ttf"
		})

		font_families.update("FiraSansLight" => {
			:normal => "#{Rails.root}/app/assets/fonts/FiraSans-Light.ttf"
		})

		font_families.update("FiraSansLightItalic" => {
			:normal => "#{Rails.root}/app/assets/fonts/FiraSans-LightItalic.ttf"
		})
		font_families.update("FiraSansHeavy" => {
			:normal => "#{Rails.root}/app/assets/fonts/FiraSans-Heavy.ttf"
		})

		font "FiraSans"
		fill_color "2E3E4D"
		self.row = 0

		define_grid(:columns => columns,:rows => rows,:gutter => 0)
	end

	def fill_bounds(color)

		tmp_color = fill_color
		fill_color color
		fill_rectangle [bounds.left, bounds.top], bounds.right, bounds.top
		fill_color tmp_color
	end
	def background_colored_gridbox(foreground_color, background_color)
			fill_bounds background_color
			tmp_color = fill_color
			fill_color(foreground_color)
			yield
			fill_color tmp_color
	end

	def period_headline(text)
		background_colored_gridbox("FFFFFF", dark_background_color) do
			indent(10,0) {
				text text, size: 1*rem, valign: :center
			}
		end
	end

	def light_headline(text)
		background_colored_gridbox(fill_color, light_background_color) do
			indent(10,0) {
				text text, size: 1*rem, valign: :center
			}
		end
	end

	def pad_inside(left: 0, right: 0, top: 0, bottom: 0)
		bounding_box([left, bounds.height-top], width: bounds.width - left - right, height: bounds.height - top - bottom) do
			yield
		end
	end

	def draw_wednesday(opening_keynote, periods, include_start = true)
			self.row = 0
		draw_day_title "Wednesday"
		draw_break_section(location: 'Reception area', time: '08:00-09:00', title: 'Registration')
		draw_open_space_section(location: 'Dragefjellet', time: '09:00-09:15', title: 'Welcome from the organizers')
		draw_plenary_section(location: 'Dragefjellet', time: '09:15-10:15', talk: opening_keynote)

		draw_period periods[0]
		draw_break_section(location: 'Downstairs', time: '11:15-11:30', title: 'Coffee break')
		draw_period periods[1]
		draw_break_section(location: 'Restaurant', time: '12:15-13:30', title: 'Lunch')

		start_new_page
		self.row = 0
		draw_day_title "Wednesday after lunch"
		draw_period periods[2], rows_per_talk: 3
		draw_break_section(location: 'Downstairs', time: '15:00-15:15', title: 'Coffee break')
		draw_period periods[3], rows_per_talk: 3
		draw_break_section(location: 'Grand Selskapslokaler', time: '19:00-00:00', title: 'Conference dinner')
	end

	def draw_thursday(periods)
			self.row = 0
		draw_day_title "Thursday"
		draw_break_section(location: 'Reception area', time: '08:00-09:00', title: 'Registration')

		draw_period periods[0], rows_per_talk: 3
		draw_break_section(location: 'Downstairs', time: '10:30-10:45', title: 'Coffee break')
		draw_period periods[1], rows_per_talk: 3
		draw_break_section(location: 'Restaurant', time: '12:15-13:30', title: 'Lunch')

		start_new_page
		self.row = 0
		draw_day_title "Thursday after lunch"

		draw_open_space_section location: 'Dragefjellet', time: '13:30-14:00', title: 'Introduction to open spaces'
		draw_open_space_section location: 'Dragefjellet and more', time: '14:00-14:45', title: 'Open spaces 1'
		draw_open_space_section location: 'Dragefjellet and more', time: '14:45-15:30', title: 'Open spaces 2'
		draw_break_section location: 'Downstairs', time: '15:30-15:45', title: 'Coffee break'
		draw_period periods[2], rows_per_talk: 2
		draw_break_section location: 'Downstairs', time: '16:15-16:30', title: 'Coffee break'
		draw_period periods[3], rows_per_talk: 2
		draw_break_section location: 'Grand Hotel Terminus', time: '19:00-00:00', title: 'Speaker\'s dinner'
	end

	def draw_friday(closing_keynote, periods)
		self.row = 0
		draw_day_title "Friday"
		draw_break_section(location: 'Reception area', time: '08:00-09:00', title: 'Registration')

		draw_period periods[0], rows_per_talk: 3
		draw_break_section(location: 'Downstairs', time: '10:30-10:45', title: 'Coffee break')
		draw_period periods[1], rows_per_talk: 3
		draw_break_section(location: 'Restaurant', time: '12:15-13:30', title: 'Lunch')

		# start_new_page
		# self.row = 0
		# draw_day_title "Friday after lunch"

		draw_period periods[2], rows_per_talk: 2
		draw_break_section location: 'Downstairs', time: '15:00-15:15', title: 'Coffee break'
		draw_plenary_section location: 'Dragefjellet', time: '15:15-16:15', talk: closing_keynote
		draw_open_space_section location: 'Dragefjellet', time: '16:15-16:30', title: 'See you next year'
	end

	def draw_day_title(title)
		grid([row,0], [row+1,columns-1]).bounding_box do
			indent(10,0) {
				text title, size: 2*rem, valign: :center
			}
		end
		self.row += 2
	end

	def draw_break_section(location:, time:, title:)
		grid([row,0], [row,columns-1]).bounding_box do
			light_headline("#{time} #{location} - #{title}")
		end
		self.row += 1
	end

	def draw_open_space_section(location:, time:, title:)
		grid([row,0], [row,columns-1]).bounding_box do
			period_headline("#{time} #{location} - #{title}")
		end
		self.row += 1

	end

	def draw_plenary_section(location:, time:, talk:)
		grid([row,0], [row,columns-1]).bounding_box do
			period_headline("#{time} #{location}")
		end
		self.row += 1

		speakers = talk.speakers.map(&:user).map(&:full_name).join(" / ")
		grid([row,0], [row,columns-1]).bounding_box do
			background_colored_gridbox(fill_color, "EEEEEE") do
				bounding_box([10,bounds.height - rem/2], width: bounds.width-10, height: bounds.height-5){
					formatted_text_box([
							{
								text: "Keynote: #{talk.title} ",
								font: "FiraSansMedium",
								size: 1*rem
							},
							{
								text: speakers,
								font: "FiraSans",
								size: 0.8*rem
							}
					])
				}
			end
		end
		self.row += 1
	end

	def draw_period(period, rows_per_talk: 1)
		# Check if we have space for the period
		longest_period = period.slots.inject(0) { |current_max, slot| current_max = [slot.talks.length, current_max].max }
		if(row + 2 + (longest_period * (rows_per_talk + 1)) > rows)
			throw Exception.new("Could not draw period #{period}")
		end

		type_text = case period.period_type
		when "lightning"
			"Lightning talks"
		when "workshop"
			"Workshops"
		when "short_talk"
			"Short talks"
		end

		# Headline for period
		grid([row,0], [row,columns-1]).bounding_box do
			period_headline("#{period.start_time.strftime("%H:%M")} - #{period.end_time.strftime("%H:%M")} #{type_text}")
		end
		self.row += 1

		# Tracks
		track_count = period.slots.length
		if(track_count == 0)
			return
		end
		period.slots.each_with_index do |slot,index|
			draw_talk slot, index, track_count, rows_per_talk
		end
		self.row += 1 + (longest_period*rows_per_talk)
		return true
	end

	def draw_talk(slot, track_number, track_count, rows_per_talk)
		left_padding = 1
		right_padding = 1
		if(track_number == 0)
			left_padding = 0
		elsif(track_number == track_count - 1)
			right_padding = 0
		end

		columns_per_track = columns/track_count
		# Room headline
		start_column = columns_per_track*track_number
		end_column = columns_per_track*(track_number+1)-1
		grid([row,start_column], [row,end_column]).bounding_box do
			pad_inside(left: left_padding, right: right_padding) do
				light_headline(slot.room.name)
			end
		end

		# Talks
		talks = slot.talk_positions.map(&:talk)
		talks.each_with_index do |talk, talk_index|

			speakers = talk.speakers.map(&:user).map(&:full_name).join(" / ")
			grid_talk_start = row+(talk_index*rows_per_talk)+1
			grid([grid_talk_start,start_column], [grid_talk_start+(rows_per_talk-1),end_column]).bounding_box do
				pad_inside(left: left_padding, right: right_padding) do
					background_colored_gridbox(fill_color, (talk_index % 2 == 0)? "EEEEEE" : "CCCCCC") do
						bounding_box([10, bounds.height - 10], width: bounds.width - 10, height: bounds.height - 10) do
							formatted_text_box(
								[
									{
										text: "#{talk.title} ",
										font: "FiraSansMedium",
										size: 0.9*rem
									},
									{
										text: speakers,
										font: "FiraSans",
										size: 0.7*rem
									}
							])
						end
					end
				end
			end
		end
	end

end