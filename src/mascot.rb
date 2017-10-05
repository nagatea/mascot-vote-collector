require 'open-uri'
require 'mechanize'

class Mascot
  def initialize(id = 1)
    @id = id
    @url = "http://c.student.mynavi.jp/cpf/stu_007//photos/detail/#{id}"
    @agent = Mechanize.new
    @agent.max_history = 1
    @agent.open_timeout = 60
    @agent.read_timeout = 180
    @page = @agent.get(@url)
  end

  def get_title
    puts @page.search('title').inner_text
  end

  def get_id
    return @id
  end

  def get_vote
    xpath = "//*[@id='votes']"
    vote = @page.search(xpath).inner_text
    vote.slice!("投票数")
    vote.slice!("票")
    return vote
  end

  def get_name
    xpath = "//*[@id='nickname']"
    name = @page.search(xpath).inner_text
    #name.slice!(/\n/)
    return name
  end

  def get_admin
    xpath = "//*[@id='title']"
    admin = @page.search(xpath).inner_text
    return admin
  end
end

