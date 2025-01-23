public interface ISIB_InventoryService {
    
    Map<Id,Integer> getProductInventory(SIB_InventoryRequest inventoryRequest);

    void reserveInventory(SIB_InventoryRequest inventoryRequest);

    void consumeReservation(SIB_InventoryRequest inventoryRequest);
}