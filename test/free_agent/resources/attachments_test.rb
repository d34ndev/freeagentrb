require "test_helper"

class AttachmentsResourceTest < Minitest::Test
  def test_retrieve
    stub_api(:get, "attachments/33", fixture: "attachments/show_a_single_attachment")

    attachment = client.attachments.retrieve(id: 33)

    assert_equal FreeAgent::Attachment, attachment.class
    assert_equal "image/png", attachment.content_type
  end

  def test_delete
    stub_api(:delete, "attachments/33")

    assert_equal true, client.attachments.delete(id: 33)
  end
end
