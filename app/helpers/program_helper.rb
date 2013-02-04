module ProgramHelper
  
  def track(time, talks)
    "
    <tr>
      <td class=\"time\">#{time}</td>
      " +
        talks.collect { |talk|
          if talk.is_a?(Talk)
            "<td class=\"track\">
                #{link_to h(talk.title), talk} (#{talk.speaker_name}) <br>
                <span class=\"room\">#{talk.slots[0] ? talk.slots[0].room : ""}<span>
             </td>"
          else
            if talk.blank?
              "<td class=\"track\">???</td>"
            else
              "<td class=\"track\">#{talk}</td>"
            end
          end
        }.join +
    "</tr>"

  end

  def lightning_talk_slot(talks, room = "")
    "<td><ol>" +
    talks.collect { |talk|
        if talk.is_a?(Talk)
            "<li>#{link_to h(talk.title), talk} (#{talk.speaker_name})</li>"
        else
          if talk.blank?
            "<li>???</li>"
          else
            "<li>#{talk}</li>"
          end
        end
    }.join +
    "</ol><span class=\"room\">#{room}</span>" +
    "</td>"
  end

  def plenary(time, title, num_tracks = 8, room = "Dragefjellet")
    """
  <tr>
    <td>#{time}</td>
    <td colspan=\"#{num_tracks}\">#{title} <br/> <span class=\"room\">#{room}</span></td>
  </tr>
    """
  end

  def pause(time, title = "Break", num_tracks = 8)
    """
  <tr>
    <td>#{time}</td>
    <td colspan=\"#{num_tracks}\" class=\"break\">#{title}</td>
  </tr>
    """
  end

  def title_for(talk)
    if talk == nil
      "???"
    else
      talk.title
    end
  end

  def speaker_name_for(talk)
    if talk == nil
      "???"
    else
      talk.speaker_name
    end
  end
end
