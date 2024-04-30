require 'rails_helper'

RSpec.describe Accounts::UsersController, type: :request do
  let!(:account) { create(:account) }
  let!(:user) { create(:user, account: account) }
  let(:product) { create(:product, account: account) }
  let(:product_first) { Product.first }

  describe 'POST /accounts/{account.id}/products' do
    let(:valid_params) do
      { product: { name: 'Product name', identifier: 'id123', amount_in_cents: '1500,99', quantity_available: '10',
                   description: 'Product description', account_id: account.id } }
    end

    context 'when it is an unauthenticated user' do
      it 'returns unauthorized' do
        post "/accounts/#{account.id}/products"
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when it is an authenticated user' do
      before do
        sign_in(user)
      end

      context 'create product' do
        it do
          expect do
            post "/accounts/#{account.id}/products",
                 params: valid_params
          end.to change(Product, :count).by(1)
          expect(response).to redirect_to(account_products_path(account))
          expect(product_first.name).to eq('Product name')
          expect(product_first.identifier).to eq('id123')
          expect(product_first.amount_in_cents).to eq(150_099)
          expect(product_first.quantity_available).to eq(10)
          expect(product_first.description).to eq('Product description')
          expect(product_first.account_id).to eq(account.id)
        end

        context 'when quantity_available is invalid' do
          it 'when quantity_available is negative' do
            invalid_params = { product: { name: 'Product name', identifier: 'id123', amount_in_cents: '150099', quantity_available: '-10',
                                          description: 'Product description', account_id: account.id } }
            expect do
              post "/accounts/#{account.id}/products",
                   params: invalid_params
            end.to change(Product, :count).by(0)
            expect(response).to have_http_status(:unprocessable_entity)
            expect(response.body).to include('Can not be negative')
          end
        end

        context 'when amount_in_cents is invalid' do
          it 'when amount_in_cents is negative' do
            invalid_params = { product: { name: 'Product name', identifier: 'id123', amount_in_cents: '-150099', quantity_available: '10',
                                          description: 'Product description', account_id: account.id } }
            expect do
              post "/accounts/#{account.id}/products",
                   params: invalid_params
            end.to change(Product, :count).by(0)
            expect(response).to have_http_status(:unprocessable_entity)
            expect(response.body).to include('Can not be negative')
          end
        end
      end
    end
  end

  describe 'GET /accounts/{account.id}/products' do
    let!(:product) { create(:product, account: account) }
    let!(:account_2) { create(:account) }
    let!(:product_account_2) { create(:product, account: account_2) }

    context 'when it is an unauthenticated user' do
      it 'returns unauthorized' do
        get "/accounts/#{account.id}/products"
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when it is an authenticated user' do
      before do
        sign_in(user)
      end

      context 'get products' do
        it 'get products by account' do
          get "/accounts/#{account.id}/products"
          expect(response).to have_http_status(200)
          expect(response.body).to include(product.name)
          expect(response.body).to include(product.identifier)
          expect(response.body).to include(product.created_at.to_s)
          expect(response.body).not_to include(product_account_2.name)
        end
      end
    end
  end
  describe 'PACTH /accounts/{account.id}/products/{product.id}' do
    context 'when it is an unauthenticated user' do
      it 'returns unauthorized' do
        patch "/accounts/#{account.id}/products/#{product.id}"
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when it is an authenticated user' do
      before do
        sign_in(user)
      end

      context 'update product' do
        let(:valid_params) do
          { product: { name: 'Product Updated Name', amount_in_cents: '63.580,36' } }
        end
        it do
          patch "/accounts/#{account.id}/products/#{product.id}", params: valid_params
          expect(response.body).to redirect_to(account_products_path(account.id))
          expect(product_first.name).to eq('Product Updated Name')
          expect(product_first.amount_in_cents).to eq(6_358_036)
        end
        context 'when quantity_available is invalid' do
          it 'when quantity_available is negative' do
            invalid_params = { product: { quantity_available: '-30' } }
            patch "/accounts/#{account.id}/products/#{product.id}", params: invalid_params
            expect(response).to have_http_status(:unprocessable_entity)
            expect(response.body).to include('Can not be negative')
          end
        end

        context 'when amount_in_cents is invalid' do
          it 'when amount_in_cents is negative' do
            invalid_params = { product: { amount_in_cents: '-150000' } }
            patch "/accounts/#{account.id}/products/#{product.id}", params: invalid_params
            expect(response).to have_http_status(:unprocessable_entity)
            expect(response.body).to include('Can not be negative')
          end
        end
      end
    end
  end
  describe 'DELETE /accounts/{account.id}/products/{product.id}' do
    context 'when it is an unauthenticated user' do
      it 'returns unauthorized' do
        delete "/accounts/#{account.id}/products/#{product.id}"
        expect(response).to redirect_to(new_user_session_path)
      end
    end
    context 'when it is an authenticated user' do
      before do
        sign_in(user)
      end
      context 'delete the user' do
        it do
          delete "/accounts/#{account.id}/products/#{product.id}"
          expect(response.body).to redirect_to(account_products_path(account.id))
          expect(Product.count).to eq(0)
        end
      end
    end
  end
  describe 'GET /accounts/{account.id}/products/new' do
    context 'when it is an unauthenticated user' do
      it 'returns unauthorized' do
        get "/accounts/#{account.id}/products/new"
        expect(response).to redirect_to(new_user_session_path)
      end
    end
    context 'when it is an authenticated user' do
      before do
        sign_in(user)
      end
      context 'new product page' do
        it do
          get "/accounts/#{account.id}/products/new"
          expect(response).to have_http_status(200)
        end
      end
    end
  end
end
