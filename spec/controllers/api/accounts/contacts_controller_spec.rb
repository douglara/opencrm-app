require 'rails_helper'

RSpec.describe 'Contacts API', type: :request do
  let!(:account) { create(:account) }
  let!(:user) { create(:user) }
  let!(:contact) { create(:contact) }
  let(:last_contact) { Contact.last }

  describe 'POST /api/v1/accounts/{account.id}/contacts' do
    let(:valid_params) do
      { full_name: contact.full_name, phone: contact.phone, email: contact.email, custom_attributes: { "cpf": '123' } }
    end

    context 'when it is an unauthenticated user' do
      it 'returns unauthorized' do
        expect { post "/api/v1/accounts/#{account.id}/contacts", params: valid_params }.not_to change(Contact, :count)

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when it is an authenticated user' do
      context 'create contact' do
        it do
          expect do
            post "/api/v1/accounts/#{account.id}/contacts",
                 headers: { 'Authorization': "Bearer #{user.get_jwt_token}" },
                 params: valid_params
          end.to change(Contact, :count).by(1)

          expect(response).to have_http_status(:success)
          expect(last_contact.custom_attributes['cpf']).to eq('123')
        end
      end
    end
  end

  describe 'POST /api/v1/accounts/{account.id}/contacts/upsert' do
    let(:valid_params) { { full_name: 'Teste contato 1', email: 'contato@dfgsdfgfdgdfgfg.com' } }

    context 'when it is an unauthenticated user' do
      it 'returns unauthorized' do
        expect do
          post "/api/v1/accounts/#{account.id}/contacts/upsert", params: valid_params
        end.not_to change(Contact, :count)

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when it is an authenticated user' do
      context 'create contact' do
        it do
          expect do
            post "/api/v1/accounts/#{account.id}/contacts/upsert",
                 headers: { 'Authorization': "Bearer #{user.get_jwt_token}" },
                 params: valid_params
          end.to change(Contact, :count).by(1)

          expect(response).to have_http_status(:success)
        end
      end

      context 'update contact' do
        let(:valid_params) { { full_name: 'Nome novo 123456', phone: contact.phone, email: contact.email } }

        it 'update name' do
          expect do
            post "/api/v1/accounts/#{account.id}/contacts/upsert",
                 headers: { 'Authorization': "Bearer #{user.get_jwt_token}" },
                 params: valid_params
          end.to change(Contact, :count).by(0)

          expect(response).to have_http_status(:success)
          expect(contact.reload.full_name).to eq('Nome novo 123456')
        end
      end

      context 'email is blank' do
        let(:params) { { full_name: 'Teste contato email', email: '' } }
        it do
          expect do
            post "/api/v1/accounts/#{account.id}/contacts/upsert",
                 headers: { 'Authorization': "Bearer #{user.get_jwt_token}" },
                 params:
          end.to change(Contact, :count).by(1)
          expect(response).to have_http_status(:success)
          expect(last_contact.email).to eq('')
        end
      end
    end
  end

  describe 'POST /api/v1/accounts/{account.id}/contacts/search' do
    context 'when it is an unauthenticated user' do
      it 'returns unauthorized' do
        post "/api/v1/accounts/#{account.id}/contacts/search", params: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end

    let(:headers) { { 'Authorization': "Bearer #{user.get_jwt_token}", 'Content-Type': 'application/json' } }

    context 'when it is an authenticated user' do
      let!(:second_contact) { create(:contact) }
      context 'when params is valid' do
        context 'with an existing contact parameter' do
          let(:params) { { query: { full_name_cont: contact.full_name, email_cont: contact.email } }.to_json }
          it 'should returns only the matching contact' do
            post("/api/v1/accounts/#{account.id}/contacts/search",
                 headers:,
                 params:)

            expect(response).to have_http_status(:success)
            contact_list = JSON.parse(response.body)['data']
            expect(contact_list.count).to eq(1)
            expect(contact_list.first['full_name']).to eq(contact.full_name)
            expect(contact_list.none? { |c| c['full_name'] == second_contact.full_name }).to be true
          end
        end
        context 'with a non-existing contact parameter' do
          let(:params) { { query: { full_name_eq: 'yukio test 123456' } }.to_json }

          it 'should returns an empty result' do
            post("/api/v1/accounts/#{account.id}/contacts/search",
                 headers:,
                 params:)

            expect(response).to have_http_status(:success)
            contact_list = JSON.parse(response.body)['data']
            expect(contact_list.count).to eq(0)
            expect(contact_list.none? do |c|
                     c['full_name'] == second_contact.full_name || contact.full_name
                   end).to be true
          end
        end
        context 'with 9 digit' do
          let!(:contact_1) { create(:contact, phone: '+5511999999999') }
          let!(:contact_2) { create(:contact, phone: '+551199999999') }

          let(:params) { { query: { phone_cont: '99999999' } }.to_json }
          it do
            post("/api/v1/accounts/#{account.id}/contacts/search",
                 headers:,
                 params:)

            result = JSON.parse(response.body)
            expect(response).to have_http_status(:success)
            expect(result['pagination']['count']).to eq(2)
          end
        end
      end
      context 'when params is invalid' do
        context 'when there is no ransack prefix to contact params' do
          let(:params) { { query: { full_name: contact.full_name, email: contact.email } }.to_json }
          it 'should raise an error' do
            expect do
              post("/api/v1/accounts/#{account.id}/contacts/search",
                   headers:,
                   params:)
            end.to raise_error(ArgumentError, /No valid predicate for full_name/)
          end
        end
      end
    end
  end
end
