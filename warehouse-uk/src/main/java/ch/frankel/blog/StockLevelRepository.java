package ch.frankel.blog;

import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

import java.util.List;

@ApplicationScoped
public class StockLevelRepository implements PanacheRepository<StockLevel> {

    public List<StockLevel> findByProductId(Long productId) {
        return list("id.productId", productId);
    }
}
