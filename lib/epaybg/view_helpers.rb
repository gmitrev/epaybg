module Epaybg
  module ViewHelpers

    def epay_link(p)
      link_to image_tag('http://0.0.0.0:3000/images/pay_with_epay.png'), "#{p.url}/?PAGE=paylogin&ENCODED=#{p.encoded}&CHECKSUM=#{p.checksum}&URL_OK=#{p.url_ok}&URL_CANCEL=#{p.url_cancel}" 
    end

    def credit_card_link(p)
      link_to image_tag('http://0.0.0.0:3000/images/pay_with_credit_card.jpg'), "#{p.url}/?PAGE=credit_paydirect&ENCODED=#{p.encoded}&CHECKSUM=#{p.checksum}&URL_OK=#{p.url_ok}&URL_CANCEL=#{p.url_cancel}" 
    end

    def epay_button(transaction)
      form_tag transaction.url do
        hidden_field_tag("PAGE", 'paylogin') +
        hidden_field_tag("ENCODED", transaction.encoded) +
        hidden_field_tag("CHECKSUM", transaction.checksum) +
        hidden_field_tag("URL_OK", transaction.url_ok) +
        hidden_field_tag("URL_CANCEL", transaction.url_cancel) +
        image_submit_tag('pay_with_epay.png' )
      end
    end

    def credit_card_button(transaction)
      form_tag transaction.url do 
        hidden_field_tag("PAGE", 'credit_paydirect') +
        hidden_field_tag("ENCODED", transaction.encoded) +
        hidden_field_tag("CHECKSUM", transaction.checksum) +
        hidden_field_tag("LANG", "bg") +
        (hidden_field_tag("URL_OK", transaction.url_ok) if transaction.url_ok) +
        (hidden_field_tag("URL_CANCEL", transaction.url_cancel) if transaction.url_cancel) +
        image_submit_tag("pay_with_credit_card.jpg")
      end 
    end

  end
end
