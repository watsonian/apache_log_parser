class ApacheLogParser
  def self.parse(filename, rules={}, &block)
    rules = process_rules(rules)
    parse_file(filename, rules, &block)
  end
  
  private
    def self.parse_line(line)
      m = line.match(/^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}).*?(([0-9]{1,2})\/(.*?)\/([0-9]{4})):(([0-9]{2}):[0-9]{2}:[0-9]{2})\s*(.*?)\]\s*"([\w]*)\s(.*?)\sHTTP\/(.*?)"\s([0-9]{3})\s(.*?)\s*"(.*?)"\s*"(.*?)"/)
      if m
      {:ip         => m[1],
       :date       => m[2],
       :day        => m[3].to_i,
       :month      => m[4],
       :year       => m[5].to_i,
       :time       => m[6],
       :hour       => m[7].to_i,
       :zone       => m[8],
       :method     => m[9],
       :resource   => m[10],
       :http_ver   => m[11],
       :status     => m[12].to_i,
       :size       => m[13],
       :referer    => m[14],
       :user_agent => m[15]}
      else
        {}
      end
    end
  
    def self.parse_file(filename, rules={}, &block)
      File.foreach(filename) do |line|
        parsed = parse_line(line)
        if rules.any?
          # stop parsing the file if we're past the designated hour range
          break if rules[:hour] && Array(parsed[:hour]).last > Array(rules[:hour]).last
          
          # go to the next line if there are any rules that are not matched by this line
          next if rules.reject{|k,v| Array(v).include?(parsed[k]) }.any?
        end
        yield parsed
      end
    end

    def self.process_rules(rules)
      #default_options = {:date => Time.now.strftime("#{"%02d" % rules[:day] || "%d"}/%h/%Y")}
      #rules = default_options.merge(rules)
      if rules[:date]
        rules[:day], rules[:month], rules[:year] = rules[:date].split("/")
        rules[:day] = rules[:day].to_i
        rules[:year] = rules[:year].to_i
      end
      rules
    end
end