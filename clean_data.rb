require "httparty"
require "pry"

years = (2015..2016).to_a
# years.each do |year|
#   url = "https://en.wikipedia.org/w/api.php?action=query&titles=#{year}&prop=revisions&rvprop=content&format=json"
#   response = HTTParty.get(url)
#   output_file = File.new(year.to_s + ".txt", "w")
#   parsed = JSON.parse(response.body)
#   page_id = parsed["query"]["pages"].keys[0]
#   page_data = parsed["query"]["pages"]["#{page_id}"]["revisions"][0]["*"]
#   output_file.write(page_data)
#   output_file.close
# end

years.each do |year|

  is_a_date = ["[[January", "[[February", "[[March", "[[April", "[[May", "[[June", "[[July", "[[August", "[[September", "[[October", "[[November", "[[December"]
  months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

  database_file = File.new(year.to_s + "_ready.txt", "w")
  in_events = true
  while in_events == true
    #
    data_month = nil
    data_day = nil

    File.open("#{year}.txt", "r").each do |line|
      if (line.include? "==Births==") || (line.include? "==Deaths==")
        in_events = false
        break
      end

      data_info = nil
      data_ongoing = false
      data_is_range = false
      data_end_month = nil
      data_end_day = nil

      is_a_date.each do |month|

        if (line.include? month) || (line[0..1]== "**")
          month = month.gsub("[", "")
          if line.include? "==#{month}=="
            @current_month = month
          elsif line.length < 18
            day_find = line.gsub("*", "")
            day_find.gsub!("[[", "")
            @current_month = month.gsub("[", "")
            day_find.gsub!("#{@current_month}", "")
            day_find.lstrip!
            @current_day = ""
            if day_find[0].to_i != 0
              @current_day +=  day_find[0]
            end
            if (day_find[1].to_i != 0) || (day_find[1] == "0")
              @current_day +=  day_find[1]
            end
          end

          if line.include? "ongoing"
            data_ongoing = true
            line.gsub!("ongoing", "")
          end

          data_day_initial = line

          if line[0..1] == "**"
            if !@current_month.nil?
              data_month = @current_month
            else
              data_month = "January"
            end
            if !@current_day.nil?
              data_day = @current_day
            else
              data_day = nil
            end
          else
            data_month = month
            data_month.slice! "[["

            data_day_initial.slice! "* [[#{data_month}"
            data_day_initial.slice! "*[[#{data_month}"

            data_day = ""
            count = 0
            data_day_initial.each_char do |letter|
              if (letter.to_i != 0) || (letter == "0")
                data_day += letter
              end
              count += 1
              if count == 5
                if data_day == ""
                  data_day = "nil"
                  data_is_range = true
                end
                break
              end
            end
          end
          data_info = data_day_initial

          data_info_array = data_info.split("<ref")
          data_info = data_info_array[0]
          data_info.gsub!("[", "")
          data_info.gsub!("]", "")
          data_info.gsub!(";", "")
          data_info.gsub!("*", "")
          data_info.gsub!("&ndash", "")
          data_info.gsub!("\n", "")
          data_info.lstrip!
          if data_info[0].to_i != 0
            data_info.slice!(0)
            data_info.lstrip!
          end
          if (data_info[0].to_i != 0) || (data_info[0] == "0")
            data_info.slice!(0)
            data_info.lstrip!
          end
          months.each do |m|
            if data_info[0..10].include? m
              data_is_range = true
              data_end_month = m
              data_end_day = data_info.dup
              data_end_day.slice! "#{m} "
              end_day_string = ""
              if data_end_day[0].to_i != 0
                end_day_string += data_end_day[0]
              end
              if (data_end_day[1].to_i != 0) || (data_end_day[1] == "0")
                end_day_string += data_end_day[1]
              end
              data_end_day = end_day_string
              data_info.slice!"#{m} #{data_end_day}"
              data_info.slice!"|#{data_end_day}"
              data_info.lstrip!
              break
            end
          end

          if data_end_month == nil
            data_end_month = "nil"
          end
          if data_end_day == nil
            data_end_day = "nil"
          end

          if !data_day == "nil"
            data_info.slice! "#{data_day}"
          end
          break
        end
      end
      binding.pry
      if (!data_month.nil?) && (data_info != "") && (data_info != nil)
        database_file.write("#{year}, #{data_month}, #{data_day}, #{data_info}, #{data_ongoing}, #{data_is_range}, #{data_end_month}, #{data_end_day}\n")
      end
    end
  end
end
