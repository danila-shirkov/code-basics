# frozen_string_literal: true

require 'test_helper'

class MetaDescriptionTest < ActiveSupport::TestCase
  test 'removes fenced code blocks and keeps the explanation' do
    theory = "```php\n<?php echo 1;\n```\nUna variable guarda un valor para usarlo después."

    assert_equal 'Una variable guarda un valor para usarlo después.', MetaDescription.build(theory)
  end

  test 'removes an unterminated code fence' do
    assert_equal 'Texto antes.', MetaDescription.build("Texto antes.\n```php\n<?php $x = 1;")
  end

  test 'removes markdown and html markup' do
    theory = "## Título\n**Importante**: el [enlace](https://example.com) y `código` en <b>negrita</b> &amp; más."

    assert_equal 'Título Importante: el enlace y código en negrita & más.', MetaDescription.build(theory)
  end

  test 'truncates at a word boundary' do
    text = Array.new(60) { 'palabra' }.join(' ')
    result = MetaDescription.build(text, length: 50)

    assert_operator result.length, :<=, 50
    assert result.end_with?('…')
    assert_not_includes result, 'palabr…'
  end

  test 'uses the fallback when the text is empty after cleaning' do
    assert_equal 'Hola, Mundo', MetaDescription.build("```ruby\nputs 1\n```", fallback: 'Hola, Mundo')
  end

  test 'works with nil' do
    assert_equal '', MetaDescription.build(nil)
  end
end
