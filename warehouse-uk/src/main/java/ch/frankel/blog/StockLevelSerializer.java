package ch.frankel.blog;

import com.fasterxml.jackson.core.JsonGenerator;
import com.fasterxml.jackson.databind.SerializerProvider;
import com.fasterxml.jackson.databind.ser.std.StdSerializer;

import java.io.IOException;

public class StockLevelSerializer extends StdSerializer<StockLevel> {

    protected StockLevelSerializer() {
        super(StockLevel.class);
    }

    @Override
    public void serialize(StockLevel stockLevel, JsonGenerator generator, SerializerProvider serializerProvider) throws IOException {
        generator.writeStartObject();
        generator.writeNumberField("product_id", stockLevel.getId().getProductId());
        generator.writeNumberField("quantity", stockLevel.getQuantity());
        generator.writeObjectField("warehouse", stockLevel.getWarehouse());
        generator.writeEndObject();
    }
}
