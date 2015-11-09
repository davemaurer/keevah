class Cart
  attr_accessor :cart_items

  def initialize(cart_items)
    @cart_items = cart_items || Hash.new
  end

  def add_item(loan_request_id, amount)
    @cart_items[loan_request_id] ||= 0
    @cart_items[loan_request_id] += amount.to_i
  end

  def cart_items_and_amount
    loan_requests = Hash.new
    cart_items.select { |loan_id, amount| loan_requests[LoanRequest.find(loan_id)] = amount }
    loan_requests
  end

  def delete_loan_request(loan_request_id)
    @cart_items.delete(loan_request_id)
  end

  def increase_loan_request_amount(loan_request_id)
    @cart_items[loan_request_id] += 25
  end

  def decrease_loan_request_amount(loan_request_id)
    if @cart_items[loan_request_id] > 25
      @cart_items[loan_request_id] -= 25
    else
      @cart_items.delete(loan_request_id)
    end
  end
end
