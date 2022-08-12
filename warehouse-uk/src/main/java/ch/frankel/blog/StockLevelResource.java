package ch.frankel.blog;

import jakarta.inject.Inject;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

import java.util.List;

@Path("/stocks")
@Produces(MediaType.APPLICATION_JSON)
public class StockLevelResource {

    private final StockLevelRepository repository;

    @Inject
    public StockLevelResource(StockLevelRepository repository) {
        this.repository = repository;
    }

    @GET
    public List<StockLevel> stockLevels() {
        return StockLevel.findAll().list();
    }

    @GET
    @Path("/{id}")
    public List<StockLevel> stockLevels(@PathParam("id") Long id) {
        return repository.findByProductId(id);
    }
}
