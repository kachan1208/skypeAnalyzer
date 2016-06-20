require "sqlite3"
require "pp"
require "unicode_utils/downcase"

def mergeKeys(keys, row)
  result = {}
  keys.each_with_index { | keyValue, index |
    result[keyValue] = row[index]
  }

  return result
end

path = 'main.db'
result = {}

patternRemove = [ /<partlist.*<\/partlist>/m,
                  /<quote.*<\/quote>/m,
                  /<URIObject.*<\/URIObject>/m,
                  /<a href.*<\/a>/m,
                  /<files.*<\/files>/m,
                  /<ss.*<\/ss>/m,
                  /<systemMessage.*<\/systemMessage>/m,
                  /[.,()\[\]:;?!\\\d]/m,
                  /<uriobject.*<\/uriobject>/m,
                  '&quot',
                  '&apos',
                  '&lt',
                  '&gt',
                  '&amp'
                ]

db = SQLite3::Database.new(path)
messages = db.execute2("SELECT timestamp, body_xml FROM messages")
columns = messages.shift

messages.each { |row|
  buff = mergeKeys(columns, row) 
  next unless patternRemove.each {|pattern|
    break if buff['body_xml'].nil?
    buff['body_xml'] = UnicodeUtils.downcase(buff['body_xml'])
    buff['body_xml'].gsub!(pattern, '')
  }

  message = buff['body_xml'].split
  message.each { |word|
    if result[word].nil?
      result[word] = 1
      next
    end


    result[word] += 1 
  }
}

pp result.sort {|x,y| y[1] <=> x[1]}
