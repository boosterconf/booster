class TalksStuffController < ApplicationController

  before_filter :require_admin

  def index
    @talks = Talk.all

    respond_to do |format|
      format.html
      format.pdf do
        pdf = TalkPdf.new(@talks, view_context)
        send_data pdf.render,
                  filename: "talks.pdf",
                  type: "application/pdf"
      end
    end
  end

  class TalkPdf < Prawn::Document
    def initialize(talks, view)
      super(:page_size => "A4", :margin => 30)


      font_families.update("siri" => {
                               :normal => "#{Rails.root}/app/assets/fonts/siriregular.ttf",
                               :italic => "#{Rails.root}/app/assets/fonts/siriitalic.ttf",
                               :bold => "#{Rails.root}/app/assets/fonts/siribold.ttf",
                               :bold_italic => "#{Rails.root}/app/assets/fonts/siribolditalic.ttf"
                           })

      talks.each_with_index do |talk, index|
        #fill_color "f2f0e6"

        #rectangle [-30, 390], 298, 420
        #fill
        font_size 40

        font 'siri'
        fill_color "white"

        if talk.title
          font_size 36
          text talk.title, :align => :center, :style => :bold
        else
          font_size 15
          text talk.title || '', :align => :center, :style => :bold
        end

        move_down 10
        font_size 20
        fill_color "#000000"
        text talk.speaker_name || '', :align => :center, :style => :normal

        move_down 25
        text_box talk.speaker_companies, :at => [0, 80], :align => :center

        move_down 100
        text talk.id.to_s
        move_down 25

        move_down 10
        font_size 20
        fill_color "#000000"
        text talk.appropriate_for_roles

        move_down 150

        fill_color "#000000"

        text_box talk.talk_type.name, :at => [0, 160], :align => :center

        if index < talks.size - 1
          start_new_page
        end
      end
    end
  end
end