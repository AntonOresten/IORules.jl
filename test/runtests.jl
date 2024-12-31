using IORules
using Test

@testset "IORules.jl" begin

    @testset "interface" begin

        struct Uppercase <: IORule end
        struct Pad <: IORule
            padding::String
        end
        
        IORules.apply_rule(data, ::Uppercase) = uppercase(data)
        IORules.apply_rule(data, rule::Pad) = rule.padding * data

        @testset "apply_rule" begin
            @test apply_rule("hello", Uppercase()) == "HELLO"
        end

        @testset "with_rule" begin
            io = IOBuffer()
            @test with_rule(io, Uppercase()) isa IOWithRule
        end

        @testset "write_rule" begin
            io = IOBuffer()
            write_rule(with_rule(io, Uppercase()), "hello")
            @test String(take!(io)) == "HELLO"
        end

        @testset "rule(io) syntax" begin
            io = IOBuffer()
            Uppercase()(io) do io
                write(io, "hello")
            end
            @test String(take!(io)) == "HELLO"
        end

        @testset "chain" begin
            io = IOBuffer()
            rule = Uppercase() ∘ Pad("p")
            rule(io) do io
                print(io, "HeLlO")
            end
            @test String(take!(io)) == "pHELLO"
        end

    end

    @testset "rules" begin

        @testset "Formatter" begin
            @test apply_rule("hello", Formatter(s -> uppercase(s))) == "HELLO"

            @testset "Color" begin
                @test apply_rule("hello", Color(:red)) == Base.text_colors[:red] * "hello"
            end
        end

        @testset "Split" begin
            io = IOBuffer()
            Split(s -> [s[1:2], uppercase(s[4:end])])(io) do io
                print(io, "hello")
            end
            @test String(take!(io)) == "heLO"

            @testset "LineSplit" begin
                io = IOBuffer()
                LineSplit(2)(io) do io
                    print(io, "hello")
                end
                @test String(take!(io)) == "he\nll\no"
            end
        end

        @testset "Block" begin
            io = IOBuffer()
            Block("World", :green)(io) do io
                print(io, "hello\n")
            end
            @test String(take!(io)) == "\e[32m╭─World\e[39m\n\e[32m│ \e[39mhello\n\e[32m╰───┈─┈─┈┈┈ ┈ ┈\e[39m\n"
        end

        @testset "Lines" begin
            io = IOBuffer()
            Lines()(io) do io
                print(io, "hello")
                print(io, " world")
            end
            @test String(take!(io)) == "hello world\n"

            io_with_rule = Lines()(io)
            print(io_with_rule, "hello")
            print(io_with_rule, " world")
            @test String(take!(io)) == ""
            print(io_with_rule, "\n")
            @test String(take!(io)) == "hello world\n"
        end

    end

end