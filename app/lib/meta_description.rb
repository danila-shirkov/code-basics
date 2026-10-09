# frozen_string_literal: true

# Текст для <meta name="description"> и og:description: убирает markdown и HTML (в теории уроков бывают блоки кода
# и разметка), схлопывает пробелы и обрезает по границе слова. В выдаче видно ≈155–160 символов.
module MetaDescription
  DEFAULT_LENGTH = 155

  # theory — текст урока (markdown/HTML); fallback — что использовать, если после очистки ничего не осталось
  def self.build(theory, fallback: nil, length: DEFAULT_LENGTH)
    text = clean(theory)
    text = clean(fallback) if text.blank?

    truncate(text, length)
  end

  def self.clean(raw)
    text = raw.to_s.dup
    text.gsub!(/```.*?```/m, ' ')   # блоки кода
    text.gsub!(/```.*\z/m, ' ')     # незакрытый блок кода
    text.gsub!(/`([^`]*)`/, '\1')   # код в строке
    text.gsub!(/!\[[^\]]*\]\([^)]*\)/, ' ') # картинки
    text.gsub!(/\[([^\]]*)\]\([^)]*\)/, '\1') # ссылки: остаётся текст
    text = ActionController::Base.helpers.strip_tags(text)
    text = CGI.unescapeHTML(text)
    text.gsub!(/^\s{0,3}(?:\#{1,6}|>|[-*+]|\d+\.)\s+/, '') # маркеры заголовков, цитат и списков
    text.gsub!(/(\*\*|\*)(\S(?:.*?\S)?)\1/, '\2') # выделение звёздочками
    # выделение подчёркиванием — только на границах слов, чтобы не ломать идентификаторы вида snake_case
    text.gsub!(/(?<![[:alnum:]_])(__|_)(\S(?:.*?\S)?)\1(?![[:alnum:]_])/, '\2')
    text.squish
  end

  def self.truncate(text, length = DEFAULT_LENGTH)
    ActionController::Base.helpers.truncate(text, length: length, separator: ' ', omission: '…')
  end
end
