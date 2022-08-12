package ch.frankel.blog;

import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import io.quarkus.hibernate.orm.panache.PanacheEntityBase;
import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;


/**
 * Example JPA entity defined as a Panache Entity.
 * An ID field of Long type is provided, if you want to define your own ID field extends <code>PanacheEntityBase</code> instead.
 * <p>
 * This uses the active record pattern, you can also use the repository pattern instead:
 * .
 * <p>
 * Usage (more example on the documentation)
 * <p>
 * {@code
 * public void doSomething() {
 * MyEntity entity1 = new MyEntity();
 * entity1.field = "field-1";
 * entity1.persist();
 * <p>
 * List<MyEntity> entities = MyEntity.listAll();
 * }
 * }
 */
@Entity
@JsonSerialize(using = StockLevelSerializer.class)
public class StockLevel extends PanacheEntityBase {

    @EmbeddedId
    private StockLevelId id;

    private Long quantity;
    @ManyToOne
    @JoinColumn(name = "warehouse_id", insertable = false, updatable = false)
    private Location warehouse;

    public StockLevelId getId() {
        return id;
    }

    public Long getQuantity() {
        return quantity;
    }

    public void setQuantity(Long quantity) {
        this.quantity = quantity;
    }

    public Location getWarehouse() {
        return warehouse;
    }

    public void setWarehouse(Location warehouse) {
        this.warehouse = warehouse;
    }
}
