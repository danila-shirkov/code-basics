# frozen_string_literal: true

class HTMLWithHoc < Redcarpet::Render::HTML
  include Redcarpet::Render::SmartyPants
  # TODO: implement hoc
  # https://github.com/vmg/redcarpet#and-you-can-even-cook-your-own
end
