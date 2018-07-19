RSpec.describe Enex do
  it "has a version number" do
    expect(Enex::VERSION).not_to be nil
  end

  describe 'Note' do
    let(:note) {
      Enex::Note.new(
        title: "Title",
        content: "<div>Content</div>",
        export_date: Time.utc(2018, 7, 19, 12, 34, 56).getlocal,
      )
    }

    describe 'to_xml' do
      subject { note.to_xml }

      it {
        should == <<-XML
          <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE en-export SYSTEM "http://xml.evernote.com/pub/evernote-export3.dtd"><en-export export-date="20180719T123456Z"><note><title>Title</title><content><![CDATA[<div>Content</div>]]></content></note></en-export>
        XML
        .strip
        File.write("test.enex", subject)
      }
    end
  end
end
