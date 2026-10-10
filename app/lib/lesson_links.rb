# frozen_string_literal: true

# Тексты уроков (теория, инструкции, подсказки, определения) приходят из внешних репозиториев упражнений и ссылаются на страницы
# codica.la, которых нет (список — краулер 2026-10-10). Править сами тексты нельзя (они перезаписываются при загрузке курса),
# поэтому ссылки исправляются при показе урока:
# - REPLACE: страница есть под другим адресом (на сайте разделы называются по-испански: /guias, /carreras);
# - UNLINK: страницы нет, текст ссылки остаётся обычным текстом;
# - DROP: страницы нет, ссылка вместе с текстом убирается (так отдельная подсказка из одной ссылки исчезает целиком).
# Ссылки в блоках кода и адреса без markdown-ссылки не трогаем (например, пример адреса статьи в уроке про slug).
module LessonLinks
  HOST = 'https://codica.la'

  REPLACE = {
    '/guides/encoding' => '/guias/encoding',
    '/guides/how-to-search' => '/guias/how-to-search',
    '/guides/compiler' => '/guias/compiler',
    '/profesiones/backend' => '/carreras/node_js',
    '/profesiones/php' => '/carreras/php'
  }.freeze

  UNLINK = %w[
    /courses/introduction-to-programming
    /courses/java-poo-basics
  ].freeze

  DROP = %w[
    /blog/mi-gente-me-entiende-la-historia-de-la-frase-hello-world-y-sus-analogos
    /blog/naming-errors-1
  ].freeze

  MARKDOWN_LINK = /\[(?<text>[^\]]*)\]\((?<url>[^)\s]+)\)/
  CODICA_URL = %r{\Ahttps?://(?:www\.)?codica\.la(?<path>/[^?#]*)?}

  class << self
    def rewrite(text)
      return text if text.blank?

      text.gsub(MARKDOWN_LINK) do
        match = Regexp.last_match
        path = codica_path(match[:url])

        if REPLACE.key?(path)
          "[#{match[:text]}](#{HOST}#{REPLACE[path]})"
        elsif UNLINK.include?(path)
          match[:text]
        elsif DROP.include?(path)
          ''
        else
          match[0]
        end
      end
    end

    # Список подсказок: правим каждую и выбрасываем те, что после правки опустели
    def rewrite_all(texts)
      Array(texts).map { |text| rewrite(text) }.compact_blank
    end

    private

    def codica_path(url)
      path = CODICA_URL.match(url)&.[](:path)
      path&.chomp('/')
    end
  end
end
