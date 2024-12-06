# app/models/concerns/default_contract_terms.rb
module DefaultContractTerms
  extend ActiveSupport::Concern

  STANDARD_TERMS = [
    "1. SCOPE OF WORK\n" \
    "The Subcontractor agrees to perform all work as detailed in the task specifications above.",

    "2. PAYMENT TERMS\n" \
    "2.1. Payment will be made within 30 days of invoice receipt and work completion verification.\n" \
    "2.2. Final payment is subject to satisfactory completion and inspection.",

    "3. DURATION AND COMPLETION\n" \
    "3.1. Work shall commence on the specified start date.\n" \
    "3.2. The Subcontractor shall complete all work by the end date.",

    "4. QUALITY AND STANDARDS\n" \
    "4.1. All work shall be performed to professional standards.\n" \
    "4.2. Materials used shall meet industry specifications.",

    "5. INSURANCE AND LIABILITY\n" \
    "5.1. The Subcontractor shall maintain appropriate insurance coverage.\n" \
    "5.2. The Subcontractor is responsible for work-related damages.",

    "6. MODIFICATIONS\n" \
    "Any changes to the scope of work must be agreed upon in writing."
  ].join("\n\n")

  STANDARD_PAYMENT_TERMS =
    "Payment Schedule:\n" \
    "- 30% upon contract signature\n" \
    "- 40% at project midpoint\n" \
    "- 30% upon satisfactory completion"
end
