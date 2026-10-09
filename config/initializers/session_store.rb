# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# NOTE: cookie без domain: привязана к хосту (basicos.codica.la). Раньше было `domain: :all` — cookie уходила на .codica.la
# и попадала в запросы ко всем поддоменам и к основному сайту codica.la.
Rails.application.config.session_store :cookie_store, key: '_hexlet_basics_session',
                                                      expire_after: 1.month,
                                                      same_site: :lax
