namespace :radiant do
  namespace :extensions do
    namespace :galleries do
      
      desc "Runs the migration of the Galleries extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          GalleriesExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          GalleriesExtension.migrator.migrate
        end
      end
      
      desc "Copies public assets of the Galleries to the instance public/ directory."
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        puts "Copying assets from GalleriesExtension"
        Dir[GalleriesExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(GalleriesExtension.root, '')
          directory = File.dirname(path)
          mkdir_p RAILS_ROOT + directory, :verbose => false
          cp file, RAILS_ROOT + path, :verbose => false
        end
        unless GalleriesExtension.root.starts_with? RAILS_ROOT # don't need to copy vendored tasks
          puts "Copying rake tasks from GalleriesExtension"
          local_tasks_path = File.join(RAILS_ROOT, %w(lib tasks))
          mkdir_p local_tasks_path, :verbose => false
          Dir[File.join GalleriesExtension.root, %w(lib tasks *.rake)].each do |file|
            cp file, local_tasks_path, :verbose => false
          end
        end
      end  
    end
  end
end
