module Regrapher
  class Parser
    LINE_REGEX = /\[regrapher\]\[(\d+)\](.+)$/

    def parse(line)
      _, length, rest = line.match(LINE_REGEX).to_a
      if length && rest && rest.length >= 2 && (length=length.to_i) <= rest.length
        begin
          JSON.parse rest[0, length], symbolize_names: true
        rescue JSON::ParserError
          # mute exception
        end
      end
    end
  end
end