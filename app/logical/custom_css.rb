# frozen_string_literal: true

module CustomCss
  def self.parse(css)
    css.to_s.split(/\r\n|\r|\n/).map do |line|
      if line =~ /\A@import/
        line
      else
        line.gsub(/([^[:space:]])[[:space:]]*(?:!important)?[[:space:]]*(;|})/, "\\1 !important\\2")
      end
    end.join("\n")
  end

  # Parse profile CSS and scope selectors to the user profile page content.
  def self.parse_profile(css)
    parse(css).split("}").filter_map do |rule|
      next if rule.blank?

      selector, body = rule.split("{", 2)
      next if selector.blank? || body.blank?

      selector = selector.strip
      next if selector.start_with?("@")

      scoped_selector = selector.split(",").map { |part| "#c-users #a-show #{part.strip}" }.join(", ")
      "#{scoped_selector} {#{body.strip}}"
    end.join("\n")
  end
end
