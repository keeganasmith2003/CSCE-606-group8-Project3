module ApplicationHelper
  require "redcarpet"

  def render_markdown(text)
    return "" if text.blank?

    renderer = Redcarpet::Render::HTML.new(
      filter_html: true,
      hard_wrap: true,
      link_attributes: { rel: "nofollow", target: "_blank" }
    )

    markdown = Redcarpet::Markdown.new(renderer,
      autolink: true,
      tables: true,
      fenced_code_blocks: true,
      no_intra_emphasis: true
    )

    markdown.render(text).html_safe
  end
  def render_star_rating(value, max: 5)
    return "Not rated" if value.blank?

    value = value.to_i
    filled = "★" * value
    empty  = "☆" * (max - value)
    "#{filled}#{empty}"
  end
end
