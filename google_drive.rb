require 'google_drive'
require "googleauth"

class MyGoogleDrive
  def initialize(config)
    @session = GoogleDrive::Session.from_config(config)
  end
  
  def get_list
    for file in @session.files
      puts file.title
    end
  end
  
  def file_upload(file_path, file_name)
    @session.upload_from_file(file_path, file_name)
  end
  
  def file_upload(file_path, file_name, folder_name)
    @session.upload_from_file(file_path, file_name)
    file = @session.file_by_title(file_name)
    folder = @session.file_by_title(folder_name)
    folder.add(file)
    @session.root_collection.remove(file)
  end
  
  def file_export(file_path, file_name)
    file = @session.file_by_title(file_name)
    file.export_as_file(file_path)
  end

  def file_download(file_path, file_name)
    file = @session.file_by_title(file_name)
    file.download_to_file(file_path)
  end
end





