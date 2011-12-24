describe Rfm::Resultset do
	# These mocks were breaking the #initialize spec, but only when I added the Layout#modelize spec !?!?
	#   let(:server) {mock(Rfm::Server)}
	#   let(:layout) {mock(Rfm::Layout)}
  let(:server) {Rfm::Server.allocate}
  let(:layout) {Rfm::Layout.allocate}
  let(:data)   {File.read("spec/data/resultset.xml")}
  subject      {Rfm::Resultset.new(server, data, layout)}
  before(:each) do
  	server.stub!(:state).and_return({})
  end

	describe "#initialze" do
		it "calls build_records with record-xml, resultset-obj, field-meta, layout" do
			Rfm::Record.should_receive(:build_records) do  |rec,rsl,fld,lay|        #|record_xml, resultset, field_meta, layout|
				rec.size.should == 2
				rsl.foundset_count.should == 2
				fld.keys[0].should == 'memokeymaster'
				lay.should == layout
			end
			subject
		end
	
		it "sets instance variables to non-nil" do
			atrs = [:layout, :server, :field_meta, :portal_meta, :date_format, :time_format, :timestamp_format, :total_count, :foundset_count]
			atrs.each {|atr| subject.send(atr).should_not eql(nil)}
		end
		
		it "loads @portal_meta with portal descriptions" do
			Rfm::Resultset.new(@Server, RESULTSET_PORTALS_XML, @Layout).portal_meta['buyouts']['PurchaseOrderNumber'].global.should == 'no'
		end
		
	end # initialize

end # Rfm::Resultset