module system

export Spin, SpinCollection, CavityMode, CavitySpinCollection

using LinearAlgebra

"""
Abstract base class for all systems defined in this library.

Currently there are following concrete systems:

* Spin
* SpinCollection
* CavityMode
* CavitySpinCollection
"""
abstract type System end


"""
A class representing a single spin.

A spin is defined by its position and its detuning to a main
frequency.

# Arguments
* `position`: A vector defining a point in R3.
* `delta`: Detuning.
"""
struct Spin <: System
    position::Vector{Float64}
    delta::Float64
    function Spin(position::Vector{T}; delta::Real=0.) where T<:Real
        new(position, delta)
    end
end


"""
A class representing a system consisting of many spins.

# Arguments
* `spins`: Vector of spins.
* `polarization`: Unit vector defining the polarization axis.
* `gamma`: Decay rate. (Has to be the same for all spins.)
"""
struct SpinCollection <: System
    spins::Vector{Spin}
    polarization::Vector{Float64}
    gamma::Float64
    function SpinCollection(spins::Vector{Spin}, polarization::Vector{T}; gamma::Real=1.) where T<:Real
        new(spins, polarization/norm(polarization), gamma)
    end
end


"""
Create a SpinCollection without explicitely creating single spins.

# Arguments
* `positions`: Vector containing the positions of all single spins.
* `polarization`: Unit vector defining the polarization axis.
* `delta=0`: Detuning.
* `gamma=0`: Decay rate. (Has to be the same for all spins.
"""
function SpinCollection(positions::Vector{Vector{T1}}, polarization::Vector{T2}; delta::Real=0., gamma::Real=1.) where {T1<:Real, T2<:Real}
    SpinCollection(Spin[Spin(p; delta=delta) for p=positions], polarization; gamma=gamma)
end


"""
A class representing a single mode in a cavity.

# Arguments
* `cutoff`: Number of included Fock states.
* `delta=0` Detuning.
* `eta=0`: Pump strength.
* `kappa=0`: Decay rate.
"""
struct CavityMode <: System
    cutoff::Int
    delta::Float64
    eta::Float64
    kappa::Float64
    function CavityMode(cutoff::Int; delta::Number=0., eta::Number=0., kappa::Number=0.)
        new(cutoff, delta, eta, kappa)
    end
end


"""
A class representing a cavity coupled to many spins.

# Arguments
* `cavity`: A CavityMode.
* `spincollection`: A SpinCollection.
* `g`: A vector defing the coupling strengths between the i-th spin and
    the cavity mode. Alternatively a single number can be given for
    identical coupling for all spins.
"""
struct CavitySpinCollection <: System
    cavity::CavityMode
    spincollection::SpinCollection
    g::Vector{Float64}
    function CavitySpinCollection(cavity::CavityMode, spincollection::SpinCollection, g::Vector{T}) where T<:Real
        @assert length(g) == length(spincollection.spins)
        new(cavity, spincollection, g)
    end
end

CavitySpinCollection(cavity::CavityMode, spincollection::SpinCollection, g::Real) = CavitySpinCollection(cavity, spincollection, ones(Float64, length(spincollection.spins))*g)

end # module
