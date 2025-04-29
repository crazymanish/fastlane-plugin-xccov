describe Fastlane::Actions::XccovAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The xccov plugin is working!")

      Fastlane::Actions::XccovAction.run(nil)
    end
  end
end
