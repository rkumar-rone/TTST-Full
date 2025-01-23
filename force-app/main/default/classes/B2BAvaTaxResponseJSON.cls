public with sharing class B2BAvaTaxResponseJSON {
    public string id;
    public String code;
    public Decimal companyId;
    public String status;
    public String type;
    public String batchCode;
    public String currencyCode;
    public String customerUsageType;
    public String entityUseCode;
    public String customerVendorCode;
    public String customerCode;
    public String exemptNo;
    public boolean reconciled;
    public String locationCode;
    public String reportingLocationCode;
    public String purchaseOrderNo;
    public String referenceCode;
    public String salespersonCode;
    public String taxOverrideType;
    public Decimal taxOverrideAmount;
    public String taxOverrideReason;
    public Decimal totalAmount;
    public Decimal totalExempt;
    public Decimal totalDiscount;
    public Double totalTax;
    public Decimal totalTaxable;
    public Double totalTaxCalculated;
    public String adjustmentReason;
    public String adjustmentDescription;
    public boolean locked;
    public String region;
    public String country;
    public Decimal version;
    public String softwareVersion;
    public Decimal originAddressId;
    public Decimal destinationAddressId;
    public Decimal exchangeRate;
    public boolean isSellerImporterOfRecord;
    public String description;
    public String email;
    public String businessIdentificationNo;
    public Decimal modifiedUserId;
    public cls_lines[] lines;
    public cls_addresses[] addresses;
    public cls_locationTypes[] locationTypes;
    public cls_summary[] summary;

    public class cls_lines {
        public Decimal id;
        public Decimal transactionId;
        public String lineNumber;
        public Decimal boundaryOverrideId;
        public String customerUsageType;
        public String entityUseCode;
        public String description;
        public Decimal destinationAddressId;
        public Decimal originAddressId;
        public Decimal discountAmount;
        public Decimal discountTypeId;
        public Decimal exemptAmount;
        public Decimal exemptCertId;
        public String exemptNo;
        public boolean isItemTaxable;
        public boolean isSSTP;
        public String itemCode;
        public Decimal lineAmount;
        public Decimal quantity;
        public String ref1;
        public String ref2;
        public String reportingDate;
        public String revAccount;
        public String sourcing;
        public Double tax;
        public Decimal taxableAmount;
        public Double taxCalculated;
        public Double nonTaxableAmount;
        public String taxCode;
        public Decimal taxCodeId;
        public String taxDate;
        public String taxEngine;
        public String taxOverrideType;
        public String businessIdentificationNo;
        public Decimal taxOverrideAmount;
        public String taxOverrideReason;
        public boolean taxIncluded;
        public cls_details[] details;
        public cls_nonPassthroughDetails[] nonPassthroughDetails;
        public cls_lineLocationTypes[] lineLocationTypes;
        public String hsCode;
        public Decimal costInsuranceFreight;
        public String vatCode;
        public Decimal vatNumberTypeId;
    }

    public class cls_details {
        public Decimal id;
        public Decimal transactionLineId;
        public Decimal transactionId;
        public Decimal addressId;
        public String country;
        public String region;
        public String countyFIPS;
        public String stateFIPS;
        public Decimal exemptAmount;
        public Decimal exemptReasonId;
        public boolean inState;
        public String jurisCode;
        public String jurisName;
        public Decimal jurisdictionId;
        public String signatureCode;
        public String stateAssignedNo;
        public String jurisType;
        public String jurisdictionType;
        public Decimal nonTaxableAmount;
        public Decimal nonTaxableRuleId;
        public String nonTaxableType;
        public Double rate;
        public Decimal rateRuleId;
        public Decimal rateSourceId;
        public String serCode;
        public String sourcing;
        public Double tax;
        public Decimal taxableAmount;
        public String taxType;
        public String taxSubTypeId;
        public String taxTypeGroupId;
        public String taxName;
        public Decimal taxAuthorityTypeId;
        public Decimal taxRegionId;
        public Double taxCalculated;
        public Decimal taxOverride;
        public String rateType;
        public String rateTypeCode;
        public Decimal taxableUnits;
        public Decimal nonTaxableUnits;
        public Decimal exemptUnits;
        public String unitOfBasis;
        public boolean isNonPassThru;
        public boolean isFee;
    }

    public class cls_nonPassthroughDetails {
    }

    public class cls_lineLocationTypes {
        public Decimal documentLineLocationTypeId;
        public Decimal documentLineId;
        public Decimal documentAddressId;
        public String locationTypeCode;
    }

    public class cls_addresses {
        public Decimal id;
        public Decimal transactionId;
        public String boundaryLevel;
        public String line1;
        public String line2;
        public String line3;
        public String city;
        public String region;
        public String postalCode;
        public String country;
        public Decimal taxRegionId;
        public String latitude;
        public String longitude;
    }

    public class cls_locationTypes {
        public Decimal documentLocationTypeId;
        public Decimal documentId;
        public Decimal documentAddressId;
        public String locationTypeCode;
    }

    public class cls_summary {
        public String country;
        public String region;
        public String jurisType;
        public String jurisCode;
        public String jurisName;
        public Decimal taxAuthorityType;
        public String stateAssignedNo;
        public String taxType;
        public String taxSubType;
        public String taxName;
        public String rateType;
        public Decimal taxable;
        public Double rate;
        public Double tax;
        public Double taxCalculated;
        public Decimal nonTaxable;
        public Decimal exemption;
    }

    public static B2BAvaTaxResponseJSON parse(String json){
        return (B2BAvaTaxResponseJSON) System.JSON.deserialize(json, B2BAvaTaxResponseJSON.class);
    }
}