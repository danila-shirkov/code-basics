# frozen_string_literal: true

require 'test_helper'

class LessonLinksTest < ActiveSupport::TestCase
  test 'guides moved to /guias' do
    assert_equal 'ver [la guía](https://codica.la/guias/compiler)', LessonLinks.rewrite('ver [la guía](https://codica.la/guides/compiler/)')
    assert_equal '[x](https://codica.la/guias/encoding)', LessonLinks.rewrite('[x](https://codica.la/guides/encoding)')
    assert_equal '[x](https://codica.la/guias/how-to-search)', LessonLinks.rewrite('[x](https://codica.la/guides/how-to-search/)')
  end

  test 'professions point to the careers that exist' do
    assert_equal '[Backend](https://codica.la/carreras/node_js)', LessonLinks.rewrite('[Backend](https://codica.la/profesiones/backend)')
    assert_equal '[PHP](https://codica.la/carreras/php)', LessonLinks.rewrite('[PHP](https://codica.la/profesiones/php)')
  end

  test 'a link to a page that does not exist keeps its text' do
    text = 'en el curso [POO en Java](https://codica.la/courses/java-poo-basics). Fin'

    assert_equal 'en el curso POO en Java. Fin', LessonLinks.rewrite(text)
  end

  test 'a dropped link disappears with its text, and an empty tip is removed' do
    tips = [
      "[Un poco sobre 'Hello, World!'](https://codica.la/blog/mi-gente-me-entiende-la-historia-de-la-frase-hello-world-y-sus-analogos)",
      '[Nomenclatura](https://codica.la/blog/naming-in-programming) [Errores](https://codica.la/blog/naming-errors-1)'
    ]

    assert_equal ['[Nomenclatura](https://codica.la/blog/naming-in-programming) '], LessonLinks.rewrite_all(tips)
  end

  test 'other links and plain urls are left alone' do
    text = "[Git](https://example.com/guides/git) y [blog](https://codica.la/blog/naming-in-programming)\n\n```\nhttps://codica.la/blog/de-obrero-a-programador\n```"

    assert_equal text, LessonLinks.rewrite(text)
  end

  test 'blank text is returned as is' do
    assert_nil LessonLinks.rewrite(nil)
    assert_equal '', LessonLinks.rewrite('')
    assert_equal [], LessonLinks.rewrite_all(nil)
  end
end
