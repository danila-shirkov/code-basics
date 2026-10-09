# frozen_string_literal: true

Configus.build Rails.env do
  env :production do
    hexlet_basics_release_version ENV.fetch('HEXLET_BASICS_RELEASE_VERSION', nil)

    # Значения Codica (раньше в production стояли значения Hexlet, а настройки Codica жили только в development)
    protocol :https
    host ENV.fetch('APP_HOST', 'basicos.codica.la')
    https_host "https://#{ENV.fetch('APP_HOST', 'basicos.codica.la')}"

    github do
      app_id ENV.fetch('GITHUB_CLIENT_ID', nil)
      app_secret ENV.fetch('GITHUB_CLIENT_SECRET', nil)
    end

    facebook do
      app_id ENV.fetch('FACEBOOK_CLIENT_ID', nil)
      app_secret ENV.fetch('FACEBOOK_CLIENT_SECRET', nil)
    end

    # Комментарии и метки — как сейчас на сервере (блок development); идентификаторы Hexlet в production Codica не нужны
    disqus do
      ru 'code-basics-test'
      en 'code-basics-test'
    end

    gtm_id 'GTM-KT3SQJ25'

    google do
      client do
        id ENV.fetch('GOOGLE_CLIENT_ID', nil)
        secret ENV.fetch('GOOGLE_CLIENT_SECRET', nil)
      end
    end

    mailer do
      from 'codica.latam.services@gmail.com'

      smtp do
        username ENV.fetch('SPARKPOST_SMTP_USERNAME', nil)
        password ENV.fetch('SPARKPOST_SMTP_PASSWORD', nil)
      end
    end

    sitemap do
      bucket do
        name ENV.fetch('DO_SPACES_SITEMAP_BUCKET', nil)
        credentials do
          access_key_id ENV.fetch('DO_SPACES_ACCESS_ID', nil)
          secret_access_key ENV.fetch('DO_SPACES_SECRET_KEY', nil)
          region 'us-east-1'
          endpoint "https://#{ENV.fetch('DO_SPACES_REGION', 'nyc3')}.digitaloceanspaces.com"
        end
      end
    end
  end

  env :development, parent: :production do
    protocol :https
    host 'code-basics.test'
    gtm_id 'GTM-KT3SQJ25'
    disqus do
      ru 'code-basics-test'
      en 'code-basics-test'
    end
  end

  env :test, parent: :development do
    github do
      app_id
      app_secret
    end
  end
end
