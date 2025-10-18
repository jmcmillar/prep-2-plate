Rails.application.config.after_initialize do
  next unless defined?(ActiveStorage::Service::S3Service)

  ActiveStorage::Service::S3Service.prepend(
    Module.new do
      def upload(key, io, checksum: nil, **options)
        # Cloudflare R2 rejects multiple checksum headers (Rails 8 sends two)
        options.delete(:checksum_algorithm)
        super(key, io, checksum: nil, **options)
      end
    end
  )
end
