module Epaybg
  module ViewHelpers
    def link_base(p, action, image = '')
      link_to image_tag(image), "#{p.url}/?PAGE=#{action}&ENCODED=#{p.encoded}&CHECKSUM=#{p.checksum}&URL_OK=#{p.url_ok}&URL_CANCEL=#{p.url_cancel}"
    end

    def epay_link(p)
      link_base p, 'paylogin', 'pay_with_epay.png'
    end

    def credit_card_link(p)
      link_base p, 'credit_paydirect', 'pay_with_credit_card.jpg'
    end
  end
end
