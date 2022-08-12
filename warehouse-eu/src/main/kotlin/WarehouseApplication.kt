package ch.frankel.blog

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RestController
import reactor.core.publisher.Flux


@RestController
class StockLevelController(private val repository: StockLevelRepository) {

    @GetMapping("/stocks")
    fun stockLevels(): Flux<StockLevel> = repository.findAll()

    @GetMapping("/stocks/{id}")
    suspend fun stockLevel(@PathVariable("id") id: Long) = repository.findByIdWithWarehouse(id)
}

@SpringBootApplication(proxyBeanMethods = false)
class WarehouseApplication

fun main(args: Array<String>) {
    runApplication<WarehouseApplication>(*args)
}
