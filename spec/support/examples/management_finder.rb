shared_examples_for "a management finder" do
  def full_path(path)
    'https://www.googleapis.com/analytics/v3/management' + path
  end

  describe "with a single page of #{subject_class_name}" do
    let(:response) { stub(:body => 'some json') }
    let(:access_token) { access_token = stub(:get => response) }
    let(:user) { stub(:access_token => access_token, :api_key => nil) }

    after do
      user.should have_received(:access_token)
      access_token.should have_received(:get).with(full_path(described_class.default_path))
      response.should have_received(:body)
      MultiJson.should have_received(:decode).with('some json')
    end

    it "returns an array of all #{subject_class_name} available to a user" do
      MultiJson.stubs(:decode).returns({'items' => ['item1', 'item2']})
      described_class.stubs(:new).returns('thing1', 'thing2')

      described_class.all(user).should == ['thing1', 'thing2']

      described_class.should have_received(:new).with('item1', user)
      described_class.should have_received(:new).with('item2', user)
    end

    it "returns an empty array of #{subject_class_name} when there are no results" do
      MultiJson.stubs(:decode).returns({})
      described_class.all(user).should == []

      described_class.should have_received(:new).never
    end
  end

  describe "with a paged response for #{subject_class_name}" do
    let(:first_url) {full_path("/first_url")}
    let(:next_url) {full_path("/next_url")}
    let(:first_response) do
      stub(:body => MultiJson.encode({"items" => ["item_1"], "nextLink" => next_url} ))
    end
    let(:second_response) do
      stub(:body => MultiJson.encode({"items" => ["item_2"]} ))
    end
    let(:access_token) do
      access_token = stub
      access_token.stubs(:get).returns(first_response, second_response)
      access_token
    end
    let(:large_user) do
      user = stub
      user.stubs(:access_token).returns(access_token)
      user.stubs(:api_key).returns(nil)
      user
    end

    it "returns an array of all #{subject_class_name}" do
      res = described_class.all(large_user, first_url)
      res.each do |result|
        expect(result.class).to eq(described_class)
      end
    end
  end
end
