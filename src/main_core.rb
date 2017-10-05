require 'open-uri'
require 'mechanize'
require 'csv'

require "./mascot.rb"
require "./google_drive.rb"
require "./create_config.rb"

Encoding.default_external = 'utf-8'

#ENV['SSL_CERT_FILE'] = File.expand_path("./cacert.pem")

class MascotMain
  def initialize
    @config = CreateConfig.new()
    @config.save_json("./tmp/config.json")
    @google_drive = MyGoogleDrive.new("./tmp/config.json")
    utc_time = Time.now
    time = utc_time + (60*60*8)
    y_time = time - (60*60*24)
    @month = time.month
    @day = time.day
    @y_month = y_time.month
    @y_day = y_time.day
    @all_id = 55
  end

  def pre_collection
    res = "id,name,admin\n"
    for i in 1..@all_id do
      begin
        mascot = Mascot.new(i)
        id = mascot.get_id
        name = mascot.get_name
        admin = mascot.get_admin
        vote = mascot.get_vote
        res = res << "#{id},#{name},#{admin}\n"
        puts(id)
        puts(name)
        puts(admin)
        puts(vote)
        puts("-----")
        sleep(1)
      rescue => exception
      end
    end
    puts(res)
    return res
  end

  def collection
    res = "id,#{@month.to_s}/#{@day.to_s}\n"
    for i in 1..@all_id do
      begin
        mascot = Mascot.new(i)
        id = mascot.get_id
        name = mascot.get_name
        admin = mascot.get_admin
        vote = mascot.get_vote
        res = res << "#{id},#{vote}\n"
        puts(id)
        puts(name)
        puts(admin)
        puts(vote)
        puts("-----")
        sleep(1)
      rescue => exception
      end
    end
    puts(res)
    return res
  end

  def make_file_name(name, type)
    if type == 0
      month_s = @month
      day_s = @day
      month_s = "0" << @month.to_s if @month < 10
      day_s = "0" << @day.to_s if @day < 10
      file_name = "#{name}#{month_s}#{day_s}.csv"
      return file_name
    else
      month_s = @y_month
      day_s = @y_day
      month_s = "0" << @y_month.to_s if @y_month < 10
      day_s = "0" << @y_day.to_s if @y_day < 10
      file_name = "#{name}#{month_s}#{day_s}.csv"
      return file_name
    end
  end

  def save_csv(res)
    file_name = self.make_file_name("mascot", 0)
    file_path = "./tmp/#{file_name}"
    puts(file_name)
    File.open(file_path, "w") do |file|
      file.write(res)
    end
  end

  def merge_save_csv(merged, file1, file2)
    CSV.open(merged, "wb") do |csv|
      header_printed = true
      self.merge_array_from_csv(file1, file2).each do |element|
        csv << element
      end
    end
  end

  def merge_array_from_csv(file1, file2)
    list1 = load_csv(file1)
    list2 = load_csv(file2)

    generated_array = []
    generated_array_element = []

    for i in 0..(list1.count.to_i - 1)
      for j in 0..(list2.count.to_i - 1)
        if (list1[i][0] == list2[j][0])
          generated_array_element = list1[i]
          generated_array_element.push(list2[j][1])
          generated_array << generated_array_element
          generated_array_element = []
        end
      end
    end
    return generated_array
  end

  def load_csv(target_file_name)
    return CSV.parse(open(target_file_name, headers: true).read)
  end

  def preparation
    self.save_csv(self.pre_collection)
    puts("save done")
    file_name_mascot = self.make_file_name("mascot", 0)
    file_path_mascot = "./tmp/#{file_name_mascot}"
    @google_drive.file_upload(file_path_mascot, file_name_mascot, "mascot")
    puts("upload done #{file_name_mascot}")
    @config.delete_json("./tmp/config.json")
  end

  def run
    self.save_csv(self.collection)
    puts("save done")
    file_name_mascot = self.make_file_name("mascot", 0)
    file_path_mascot = "./tmp/#{file_name_mascot}"
    @google_drive.file_upload(file_path_mascot, file_name_mascot, "mascot")
    puts("upload done #{file_name_mascot}")
    file_name_master = self.make_file_name("master", 1)
    file_path_master = "./tmp/#{file_name_master}"
    @google_drive.file_export(file_path_master, file_name_master)
    puts("download done #{file_name_master}")
    file_name_merge = self.make_file_name("master", 0)
    file_path_merge = "./tmp/#{file_name_merge}"
    self.merge_save_csv(file_path_merge, file_path_master, file_path_mascot)
    puts("merge done #{file_name_merge}")
    @google_drive.file_upload(file_path_merge, file_name_merge, "mascot")
    puts("upload done #{file_name_merge}")
    @config.delete_json("./tmp/config.json")
  end

end

runer = MascotMain.new()

runer.run


