package ch.frankel.blog;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;

import java.io.Serializable;
import java.util.Objects;

@Embeddable
public class StockLevelId implements Serializable {

    @Column(name = "product_id")
    private Long productId;
    @Column(name = "warehouse_id")
    private Long warehouseId;

    public Long getProductId() {
        return productId;
    }

    public Long getWarehouseId() {
        return warehouseId;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        StockLevelId that = (StockLevelId) o;
        return Objects.equals(productId, that.productId) && Objects.equals(warehouseId, that.warehouseId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(productId, warehouseId);
    }
}
