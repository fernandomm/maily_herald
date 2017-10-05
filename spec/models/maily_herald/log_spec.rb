require 'rails_helper'

describe MailyHerald::Log do

  let!(:entity) { create :user }
  let!(:mailing) { create :weekly_summary }

  context "associations" do
    let!(:log) { MailyHerald::Log.create_for mailing, entity, {status: :delivered} }

    it { expect(log).to be_valid }
    it { expect(log.entity).to eq(entity) }
    it { expect(log.mailing).to eq(mailing) }

    it { expect(MailyHerald::Log.for_entity(entity)).to include(log) }
    it { expect(MailyHerald::Log.for_mailing(mailing)).to include(log) }

    it { expect(MailyHerald::Log.for_entity(entity).for_mailing(mailing).last).to eq(log) }
  end

  context "scopes" do
    let!(:entity2) { create :user }
    let!(:log1) { MailyHerald::Log.create_for mailing, entity, {status: :delivered} }
    let!(:log2) { MailyHerald::Log.create_for mailing, entity2, {status: :delivered} }

    it { expect(MailyHerald::Log.count).to eq(2) }

    context "#skipped" do
      before { log1.update_attributes!(status: :skipped) }

      it { expect(MailyHerald::Log.skipped.count).to eq(1) }
    end

    context "#error" do
      before { log1.update_attributes!(status: :error) }

      it { expect(MailyHerald::Log.error.count).to eq(1) }
    end

    context "#for_entity" do
      it { expect(MailyHerald::Log.for_entity(entity).count).to eq(1) }
      it { expect(MailyHerald::Log.for_entity(entity2).count).to eq(1) }
    end

    context "#like_email" do
      it { expect(MailyHerald::Log.like_email(entity.email[0..2]).count).to eq(1) }
      it { expect(MailyHerald::Log.like_email(entity2.email[0..2]).count).to eq(1) }
    end
  end

end
