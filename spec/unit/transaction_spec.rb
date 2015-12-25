RSpec.describe CallSheet::Transaction do
  subject(:container) {
    {
      upcase: -> input { input.upcase },
      reverse: -> input { input.reverse },
      exclaim_all: -> input { input.split(" ").map { |str| str + "!" }.join(" ") },
    }
  }

  describe "#prepend" do
    let(:initial_transaction) {
      CallSheet(container: container) do
        map :exclaim_all
      end
    }

    it "prepends the transaction" do
      other_transaction = CallSheet(container: container) do
        map :reverse
      end
      new_transaction = initial_transaction.prepend(other_transaction)

      expect(new_transaction.call("hello world").right).to eq "dlrow! olleh!"
    end

    it "accepts a transaction defined in a block" do
      new_transaction = initial_transaction.prepend(container: container) do
        map :reverse
      end

      expect(new_transaction.call("hello world").right).to eq "dlrow! olleh!"
    end

    it "raises an argument error if a transaction is neither passed nor defined" do
      expect { initial_transaction.prepend }.to raise_error(ArgumentError)
    end

    it "leaves the original transaction unmodified" do
      new_transaction = initial_transaction.prepend(container: container) do
        map :reverse
      end

      expect(initial_transaction.call("the quick brown fox").right).to eq "the! quick! brown! fox!"
    end
  end

  describe "#append" do
    let(:initial_transaction) {
      CallSheet(container: container) do
        map :upcase
      end
    }

    it "appends the transaction" do
      other_transaction = CallSheet(container: container) do
        map :exclaim_all
      end
      new_transaction = initial_transaction.append(other_transaction)

      expect(new_transaction.call("the quick brown fox").right).to eq "THE! QUICK! BROWN! FOX!"
    end

    it "accepts a transaction defined in a block" do
      new_transaction = initial_transaction.append(container: container) do
        map :exclaim_all
      end

      expect(new_transaction.call("the quick brown fox").right).to eq "THE! QUICK! BROWN! FOX!"
    end

    it "raises an argument error if a transaction is neither passed nor defined" do
      expect { initial_transaction.insert(before: :reverse) }.to raise_error(ArgumentError)
    end

    it "leaves the original transaction unmodified" do
      new_transaction = initial_transaction.append(container: container) do
        map :exclaim_all
      end

      expect(initial_transaction.call("the quick brown fox").right).to eq "THE QUICK BROWN FOX"
    end
  end

  describe "#remove" do
    let(:initial_transaction) {
      CallSheet(container: container) do
        map :upcase
        map :exclaim_all
        map :reverse
      end
    }

    let!(:new_transaction) { initial_transaction.remove(:exclaim_all, :reverse) }

    it "removes the specified steps" do
      expect(new_transaction.call("the quick brown fox").right).to eq "THE QUICK BROWN FOX"
    end

    it "leaves the original transaction unmodified" do
      expect(initial_transaction.call("the quick brown fox").right).to eq "!XOF !NWORB !KCIUQ !EHT"
    end
  end

  describe "#insert" do
    let(:initial_transaction) {
      CallSheet(container: container) do
        map :upcase
        map :reverse
      end
    }

    it "accepts a transaction passed as an argument" do
      other_transaction = CallSheet(container: container) do
        map :exclaim_all
      end
      new_transaction = initial_transaction.insert(other_transaction, before: :reverse)

      expect(new_transaction.call("the quick brown fox").right).to eq "!XOF !NWORB !KCIUQ !EHT"
    end

    it "accepts a transaction defined in a block" do
      new_transaction = initial_transaction.insert(before: :reverse, container: container) do
        map :exclaim_all
      end

      expect(new_transaction.call("the quick brown fox").right).to eq "!XOF !NWORB !KCIUQ !EHT"
    end

    it "raises an argument error if a transaction is neither passed nor defined" do
      expect { initial_transaction.insert(before: :reverse) }.to raise_error(ArgumentError)
    end

    it "raises an argument error if an invalid step name is provided" do
      expect {
        initial_transaction.insert(before: :non_existent, container: container) do
          map :exclaim_all
        end
      }.to raise_error(ArgumentError)
    end

    context "before" do
      let!(:new_transaction) {
        initial_transaction.insert(before: :reverse, container: container) do
          map :exclaim_all
        end
      }

      it "inserts the new steps before the specified one" do
        expect(new_transaction.call("the quick brown fox").right).to eq "!XOF !NWORB !KCIUQ !EHT"
      end

      it "leaves the original transaction unmodified" do
        expect(initial_transaction.call("the quick brown fox").right).to eq "XOF NWORB KCIUQ EHT"
      end
    end

    context "after" do
      let!(:new_transaction) {
        initial_transaction.insert(after: :reverse, container: container) do
          map :exclaim_all
        end
      }

      it "inserts the new steps after the specified one" do
        expect(new_transaction.call("the quick brown fox").right).to eq "XOF! NWORB! KCIUQ! EHT!"
      end

      it "leaves the original transaction unmodified" do
        expect(initial_transaction.call("the quick brown fox").right).to eq "XOF NWORB KCIUQ EHT"
      end
    end
  end
end
